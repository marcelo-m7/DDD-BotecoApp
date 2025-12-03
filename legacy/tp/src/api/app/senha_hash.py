import bcrypt

senha = "1234"
hash = bcrypt.hashpw(senha.encode('utf-8'), bcrypt.gensalt())
print(hash.decode())
