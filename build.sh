#!/bin/bash

mkdir -p build

for file in modules/*.asm; do
    filename=$(basename "$file" .asm)
    echo "Assembling module: $filename"
    nasm -f elf32 "$file" -o "build/$filename.o"
done

echo "Assembling main.asm"
nasm -f elf32 main.asm -o build/main.o

echo "Linking..."
ld -m elf_i386 build/*.o -o build/program

if [ $? -eq 0 ]; then
    echo "--- Running Program ---"
    ./build/program
else
    echo "Linking failed."
fi