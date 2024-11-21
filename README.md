# Assembly-Encryption
This was my final project for CISP 310, "Assembly Language Programming for Microcomputers", at Sacramento City College, Fall 2023.

1. The encrypt.exe program will prompt the user to input a message they wish to be encrypted, or type q to quit.
2. The encrypt program will take the message and encrypt it by either flipping all bits or rotating each character by k%8 bit rotations left, where k is the number of 'e's in the message.
3. It then writes the encrypted message, and a key telling the decrypt program how many rotations to perform, to a text file named Encrypted_Message.txt.
4. Running the decrypt.exe program automatically reads from Encrypted_Message.txt in the same directory, and decrypts it by undoing the operations performed in encrypt.exe.

This summary was written over a year after writing the program, some parts may be inaccurate.

*Note: To be ran in the terminal, encrypt.exe and decrypt.exe require execution permissions. Use "chmod +x encrypt.exe decrypt.exe" to give permission.
