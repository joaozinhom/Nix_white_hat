## Here some useful tools to learn how the things works....Be careful and respectful


start with 
```bash  
nix develop --impure
```

To easy acess to rockyou list:
```bash  
cp  $(wordlists_path)/rockyou.txt ./
```
to easy hash sha256 a password:
```bash  
echo -n "password" | sha256sum
```

to easy know the hash type, you can use hashid:
```bash  
pip install hashid
hashid -m <hash>
```

to use hashcat with sha256, put the hash in the password.txt file and run:
```bash
hashcat -m 1400 password.txt rockyou.txt -D 1 -r simple.rule
```

if your password to crack its from the bitcoin ecossystem use:
```bash
hashcat -m 1400 password.txt orangepillyou.txt -D 1 -r simple.rule
```
and both cases you can use the --show flag to see the cracked passwords