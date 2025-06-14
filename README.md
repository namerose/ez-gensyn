## 💻 System Requirements

| Requirement                         | Details                                                     |
|-------------------------------------|-------------------------------------------------------------|
| **CPU Architecture**                | `arm64` or `amd64`                                          |
| **Recommended RAM**                 | 24 GB                                                       |
| **CUDA Devices (Recommended)**      | `RTX 3090`, `RTX 4070`, `RTX 4090`, `A100`, `H100`          |
| **Python Version**                  | Python >= 3.10 (For Mac, you may need to upgrade)           |


## 📥 Installation

1. **Go `cd $HOME` First**
```bash
cd $HOME
```
2. **Install `sudo`** ( if you already availavle `sudo` you can skip this part )
```bash
apt update && apt install -y sudo
```
3. **Install Git**
```bash
sudo apt install git
```
4. **Clone Repo**  
```bash
git clone https://github.com/namerose/ez-gensyn.git
```
5. **Run**
```bash
chmod +x ez-gensyn/install.sh && ./ez-gensyn/install.sh
```
**Install**
- When the menu show select 1 and just go!

![Screenshot 2025-05-30 043943](https://github.com/user-attachments/assets/6f0976f0-a26e-4db6-bf48-4e2a6802597e)

NOW WAIT! the system is installing the rest!

When it's clear installing Follow This Step bellow

**Go to train Section**
- At this step just follow that terminal says

![Screenshot 2025-05-29 141914](https://github.com/user-attachments/assets/7f20a43e-a83e-43c9-8f3c-c6a7573547c0)
```bash
screen -r gensyn
```

## 📥 Customization

**Reduce The Fraction**
- Easily change the Fraction to reduce VRAM usage make sure for reduce OOM! ( other configuration is modified on my version RL-Swarm for reducing OOM )

![Screenshot 2025-05-29 145010](https://github.com/user-attachments/assets/5d307896-07ab-4546-82bc-312d2599f2f2)


**Change Steps, Etc**
- Easily Change Config without changing the files

![Screenshot 2025-05-29 145104](https://github.com/user-attachments/assets/638f7a36-c750-42aa-8174-4e64a8b45733)

- After Following steps you can chose wich one to use for Login ( Ngrok, Cloudflare, localtunnel or localhost ) ( if using localtunnel your password is your public server IP )

**Backup your data easily**
- Just Select Number 2 and follow the steps

![Screenshot 2025-05-30 044256](https://github.com/user-attachments/assets/0474c596-d68f-46c0-8b15-0ef319bb3f9d)

![Screenshot 2025-05-30 044343](https://github.com/user-attachments/assets/41118bcd-4f87-441f-a403-43c1c2863473)

If System Failed do Backup Recovery Swarm Data then you need to Download Manually from the SFTP instead , you can use WinSCP or Bitvise or any tools!

## ERROR ( before build server for login using tunnel)
In somecase when installing got stuck for long time just CTRL+C and then re run

![image](https://github.com/user-attachments/assets/d5b096cf-c2c4-44e4-a8b4-99e705269e61)

```bash
cd rl-swarm
```
```bash
screen
```
```bash
./run_rl_swarm.sh
```
Make sure you're on Home or cd $HOME directory !
