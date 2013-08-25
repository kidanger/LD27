#!/usr/bin/env python2
# coding: utf-8

import Image

VOID = 255, 255, 255
START = 255, 0, 0
ARRIVAL = 0, 255, 0
FUEL = 0, 0, 255
HEALTH = 255, 0, 255
TEXT1 = 0, 255, 255
TEXT2 = 255, 255, 0
TEXT3 = 0, 127, 127
TEXT4 = 130, 127, 0

def search(src, x, y, color):
    dx = 0
    dy = 0

    # search box height
    while y+dy < src.size[1]:
        p = src.getpixel((x, y+dy))
        if p != color:
            break
        dy += 1

    while x+dx < src.size[0]:
        isvalid = True
        for ddy in range(dy):
            p = src.getpixel((x+dx, y+ddy))
            if p != color:
                isvalid = False
                break
        if not isvalid:
            break
        dx += 1

    # erase the box
    for ddx in range(dx):
        for ddy in range(dy):
            src.putpixel((x+ddx, y+ddy), VOID)
    return dx, dy


def convert(name):
    pngname = name + '.png'
    luaname = name + '.lua'
    textname = name + '.txt'

    start = {'x':0, 'y':0}
    arrival = {'x':0, 'y':0}
    boxes = []
    capsules = []
    texts = []

    data = ['', '', '', '']
    try:
        tmpdata = open(textname).read().strip().split('\n')
        for i, d in enumerate(tmpdata):
            data[i] = d
    except IOError:
        pass


    src = Image.open(pngname)
    for x in range(src.size[0]):
        for y in range(src.size[1]):
            color = src.getpixel((x, y))
            if color == VOID:
                continue
            if color == START:
                start['x'] = x
                start['y'] = y
            elif color == ARRIVAL:
                arrival['x'] = x
                arrival['y'] = y
            elif color == FUEL:
                capsules += [{'type':'fuel', 'x': x, 'y': y}]
            elif color == HEALTH:
                capsules += [{'type':'health', 'x': x, 'y': y}]
            elif color == TEXT1:
                dx, dy = search(src, x, y, color)
                texts += [{'x': x, 'y': y, 'w': dx, 'h': dy, 'text': 1}]
            elif color == TEXT2:
                dx, dy = search(src, x, y, color)
                texts += [{'x': x, 'y': y, 'w': dx, 'h': dy, 'text': 2}]
            elif color == TEXT3:
                dx, dy = search(src, x, y, color)
                texts += [{'x': x, 'y': y, 'w': dx, 'h': dy, 'text': 3}]
            elif color == TEXT4:
                dx, dy = search(src, x, y, color)
                texts += [{'x': x, 'y': y, 'w': dx, 'h': dy, 'text': 4}]
            elif color[0] == color[1] == color[2]:
                dx, dy = search(src, x, y, color)
                boxes += [{'x': x, 'y': y, 'w': dx, 'h': dy}]
                print(color, boxes[-1])

    def tolua(var):
        if type(var) == str:
            return '"' + var + '"'
        if type(var) == dict:
            print('dict:', var)
            return repr(var).replace(': ', '=').replace("'", '').replace('health', '"health"').replace('fuel', '"fuel"')
        if type(var) == list:
            print('list:', var)
            string = '{\n'
            for i in var:
                string += '\t' + tolua(i) + ',\n'
            return string + '}'
        assert(False)

    luacode = 'local level = {\n'
    luacode += 'start=' + tolua(start) + ',\n'
    luacode += 'arrival=' + tolua(arrival) + ',\n'
    luacode += 'capsules=' + tolua(capsules) + ',\n'
    luacode += 'boxes=' + tolua(boxes) + ',\n'
    luacode += 'texts=' + tolua(texts) + ',\n'
    luacode += 'textdata=' + tolua(data) + ',\n'
    luacode += '}\nreturn level'
    print(luacode)
    dst = open(luaname, 'w')
    dst.write(luacode)


if __name__ == '__main__':
    if True:
        import os
        for f in os.listdir('.'):
            if f.startswith('level') and f.endswith('.png'):
                convert(f.replace('.png', ''))
    else:
        convert('level1')
