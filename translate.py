'''
Usage:
Put your test asm code in assignment3.asm
python translate.py
And the output is the machine instrucion which could be load into logisim directly
'''

from beta.assembler.assembler import assemble_str, assemble

if __name__ == '__main__':
    bytes, _ = assemble("assignment3.asm")
    assert(len(bytes) % 4 == 0)

    ans = 'v2.0 raw\n'
    i = 0
    instruction_count = 0
    while i < len(bytes):
        instruction = ''
        for j in range(4):
            byte = hex(bytes[i + j])[2:]
            if len(byte) == 1:
                byte = '0' + byte
            instruction = byte + instruction
        ans += instruction + ' '
        if instruction_count % 8 == 7:
            ans += '\n'
        instruction_count += 1
        i += 4
    ans += '\n'
    print (ans)
