import re
import os
import openpyxl
from collections import OrderedDict
from romtools.dump import BorlandPointer, PointerExcel, unpack
from romtools.disk import Gamefile
from rominfo import FILE_BLOCKS


#60 1e 06 8c c8 8e d8 be xx yy b9
pointer_regex = r'\\xd8\\xbe\\x([0-f][0-f])\\x([0-f][0-f])'
visual_pointer_regex = r'\\x1e\\x06\\xbe\\x([0-f][0-f])\\x([0-f][0-f])'

def capture_pointers_from_function(hx, regex): 
    return re.compile(regex).finditer(hx)

def location_from_pointer(pointer):
    return '0x' + str(format((unpack(pointer[0], pointer[1])), '04x'))

try:
    os.remove('rusty_pointer_dump.xlsx')
except WindowsError:
    pass
PtrXl = PointerExcel('rusty_pointer_dump.xlsx')

# TODO: Alphanumeric sort on the files still does STORY1, STORY10, STORY2, etc
for gamefile in FILE_BLOCKS:
    if gamefile in ['JO.EXE', 'OP.COM']:
        gamefile_path = os.path.join('original', gamefile)
    else:
        gamefile_path = os.path.join('original', 'decompressed_' + gamefile)
    GF = Gamefile(gamefile_path)
    with open(gamefile_path, 'rb') as f:
        bytes = f.read()
        target_areas = FILE_BLOCKS[gamefile]

        only_hex = ""
        for c in bytes:
            only_hex += '\\x%02x' % ord(c)

        if gamefile == 'VISUAL.COM':
            pointers = capture_pointers_from_function(only_hex, visual_pointer_regex)
            target_areas = None
        else:
            pointers = capture_pointers_from_function(only_hex, pointer_regex)
        pointer_locations = OrderedDict()

        for p in pointers:
            pointer_location = p.start()/4 + 2


            pointer_location = '0x%05x' % pointer_location
            text_location = location_from_pointer((p.group(1), p.group(2)),)

            if target_areas:
                if not any([t[0] <= int(text_location, 16) <= t[1] for t in target_areas]):
                    continue

            all_locations = [pointer_location,]

            if text_location in pointer_locations:
                all_locations = pointer_locations[text_location]
                all_locations.append(pointer_location)

            print GF, text_location
            pointer_locations[text_location] = all_locations

            print text_location

    # Setup the worksheet for this file
    worksheet = PtrXl.add_worksheet(GF.filename.lstrip('decompressed_'))

    row = 1

    for text_location, pointer_locations in sorted((pointer_locations).iteritems()):
        obj = BorlandPointer(GF, pointer_locations, text_location)
        print text_location
        print pointer_locations

        for pointer_loc in pointer_locations:
            worksheet.write(row, 0, text_location)
            worksheet.write(row, 1, pointer_loc)
            try:
                worksheet.write(row, 2, obj.text())
            except:
                worksheet.write(row, 2, '')
            row += 1

PtrXl.close()