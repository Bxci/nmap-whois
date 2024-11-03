#!/bin/bash

figlet -f banner "Ben Project"
sleep 2

#on that script am gonna work with "log" and without a lot of echos, because i wanna to print that to LOG_FILE.
LOG_FILE="/home/kali/Desktop/Project/s_log.txt"

#its a fucntion log i took from gpt to make the file show a tlogtemps.
function log {
    echo "$(date '+%H:%M:%S') - $1" | tee -a $LOG_FILE
}

#starting log
log "The script starting.."


#here a if to see if nipe installed or not on the machine.
if [ -d "nipe" ]; then
    log "nipe is already downloaded!"
    sleep 2
else
    #here if the nipe don't exist on the project folder its start to download that.
    log "Start installing Nipe!"
    sleep 2
    git clone https://github.com/htrgouvea/nipe > /dev/null 2>&1
    cd nipe
    #for nipe we need dependencies so here after i clone the git here a command to install the deps.
    log "Installing deps!"
    sleep 2
    sudo cpanm --installdeps . > /dev/null 2>&1
    sudo perl nipe.pl install > /dev/null 2>&1
fi

tools=('sshpass' 'nmap' 'whois')

for tool in "${tools[@]}"; do
	if ! command -v "$tool" &>/dev/null; then
    log "$tool Already installed!"
    sleep 2
    echo "$tool Already installed!"
    sleep 2
    sudo apt-get install $tool -y >/dev/null 2>&1
    log "$tool Downloaded!."
    sleep 2
    else
    log "$tool is Already Installed"
    sleep 2
    fi
done

#here after we downloaded the nipe, we need to restart them to make sure we not getting any problems with running.
cd /home/kali/Desktop/Project/nipe

log "Restarting Nipe!"
sudo perl nipe.pl restart
sleep 3
sudo perl nipe.pl restart
sleep 3

#that var for status of nipe.
N_STATUS=$(sudo perl nipe.pl status)
log "Status of nipe: $N_STATUS"
sleep 2

#let see if we are anonymous.

function ANONYMOUS() {
    IP=$(curl -s ipv4.wtfismyip.com/text)
    if [ "$(geoiplookup $IP | grep -i IL)" ]; then
        log "Your IP is not getting spoofed!, Exiting."
        echo "Your IP is not getting Anonymous!, Exiting!."
        sleep 2
        exit
    else
        S_COUNTRY=$(geoiplookup $IP | awk '{print $(NF)}')
        log "Your IP getting anonymous!"
        echo "Your getting anonymous!, spoofed country: $S_COUNTRY"
        sleep 2
    fi
}

ANONYMOUS

# -p is visible and -s its hidden
read -p "Please enter the IP you'd like to scan: " NMAP_ADDRESS
sleep 2
log "Target of scanning: $NMAP_ADDRESS" > /dev/null 2>&1

read -p "Please enter the remote machine IP address: " SSH_IP
sleep 2
log "Remote machine IP: $SSH_IP" > /dev/null 2>&1

read -p "Please enter the remote machine username: " USERNAME_MACHINE
sleep 2
log "Remote machine username: $USERNAME_MACHINE" > /dev/null 2>&1

echo -n "Please enter remote machine password: "
sleep 2
read -s REMOTE_PASSWORD
echo
log "Remote machine password entered."
sleep 2

function CONNECT() {
    CN_IP=$(sshpass -p $REMOTE_PASSWORD ssh -o StrictHostKeyChecking=no $USERNAME_MACHINE@$SSH_IP ifconfig | grep -i broadcast | awk '{print $2}')
    log "Remote Host IP: $CN_IP"
    sleep 2

    CN_COUNTRY=$(sshpass -p $REMOTE_PASSWORD ssh -o StrictHostKeyChecking=no $USERNAME_MACHINE@$SSH_IP whois $CN_IP | grep -i country | awk '{print $2}')
    log "Remote Host country $CN_COUNTRY"
	sleep 2

    CN_UPTIME=$(sshpass -p $REMOTE_PASSWORD ssh -o StrictHostKeyChecking=no $USERNAME_MACHINE@$SSH_IP uptime | awk '{print $1 $2 $3 $4}' | sed 's/:/:/; s/up/ up /')
    log "Remote machine uptime $CN_UPTIME"
	sleep 2
}

CONNECT

log "Performing whois scan on $NMAP_ADDRESS..."
sleep 2
sshpass -p $REMOTE_PASSWORD ssh -o StrictHostKeyChecking=no $USERNAME_MACHINE@$SSH_IP whois $NMAP_ADDRESS >> /home/$USERNAME_MACHINE/Desktop/Project/whois.txt
log "Whois scan saved to /home/$USERNAME_MACHINE/Desktop/Project/" >> whois.txt
sleep 2
log "Performing Nmap scan on $NMAP_ADDRESS..."
sleep 2
sshpass -p $REMOTE_PASSWORD ssh -o StrictHostKeyChecking=no $USERNAME_MACHINE@$SSH_IP nmap $NMAP_ADDRESS >> /home/$USERNAME_MACHINE/Desktop/Project/nmap.txt
log "Nmap scan saved to /home/$USERNAME_MACHINE/Desktop/Project/" >> nmap.txt
sleep 2
log "Script finished."
