with open("0403.img", "wb") as file:
    for i in range(360 * 512):
        file.write(b'\x00')
    file.seek(0, 0)
    with open("MBR.COM", "rb") as com:
        file.write(com.read())
    file.seek(512 * 18, 0)
    with open("char.COM", "rb") as f:
        file.write(f.read())
