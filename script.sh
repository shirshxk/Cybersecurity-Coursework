#!/bin/bash


encrypt_send() {
    read -p "Enter the file name you want to encrypt: " filename
    if [ ! -f "$filename" ]; then
        echo "File does not exist, enter a valid file!"
        exit 1
    fi
    read -p "Enter the path to your private key (for signing): " privatekeyA
    read -p "Enter the path to the recipient's public key (for encryption): " publickeyB

    echo "Encrypting and signing the file......"
    openssl dgst -sha256 -sign "$privatekeyA" -out "$filename.sig" "$filename"
    openssl pkeyutl -encrypt -in "$filename" -out "$filename.enc" -inkey "$publickeyB" -pubin

    echo "Sending the encrypted file and signature....."
    read -p "Enter the username for SCP transfer: " user
    read -p "Enter the IP Address for SCP transfer: " ip
    read -p "Enter the destination for SCP transfer: " folder
    scp "$filename.enc" "$filename.sig" "$user@$ip:$folder"

    echo "File has been encrypted, signed and sent successfully."
}

decrypt_verify() {
    read -p "Enter the encrypted file: " filename
    read -p "Enter the signed file: " sfilename
    if [[ ! -f "$filename" || ! -f "$sfilename" ]]; then
        echo "File does not exist, enter a valid file!"
        exit 1
    fi
    read -p "Enter the path to your private key (for decryption): " privatekeyB
    read -p "Enter the path to the public key of the sender (to verify signature): " publickeyA

    echo "Decrypting the file......"
    openssl pkeyutl -decrypt -inkey "$privatekeyB" -in "$filename" -out "decrypted.txt"

    echo "Verifying the signature...."
    if openssl dgst -sha256 -verify "$publickeyA" -signature "$sfilename" "decrypted.txt"; then
        echo "Signature was verified!"
    else
        echo "Signature verification failed!"
    fi

    echo "File has been decrypted successfully!."
}


read -p "Do you want to (1) Encrypt and send or (2) Decrypt and verify: " choice


if [ "$choice" -eq 1 ]; then
    encrypt_send
elif [ "$choice" -eq 2 ]; then
    decrypt_verify
else
    echo "Invalid choice, enter a valid number!"
    exit 1
fi
