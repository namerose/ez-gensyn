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
2. **Install `sudo`**
```bash
apt update && apt install -y sudo
```
3. **Install Git**
```bash
sudo apt install git
```
4. **do Clone Repo**  
```bash
git clone https://github.com/namerose/ez-gensyn.git
```
5. **run**
```bash
chmod +x ez-gensyn/install.sh && ./ez-gensyn/install.sh
```

**Go to train Section**
- At this step just follow that terminal says
![Screenshot 2025-05-29 141914](https://github.com/user-attachments/assets/54897c76-994e-4475-921e-3c44edea50df)
```bash
screen -r gensyn
```

## 📥 Customization

**Reduce The Fraction**
- Easily change the Fraction to reduce VRAM usage make sure for Anti OOM!
![Screenshot 2025-05-29 145010](https://github.com/user-attachments/assets/2dedfd86-6df6-4508-9963-d3a9f49d06ad)

**Change Steps, Etc**
- Easily Change Config without changing the files
![Screenshot 2025-05-29 145104](https://github.com/user-attachments/assets/06f0fcd2-a310-432b-bf04-df0aa683d780)
