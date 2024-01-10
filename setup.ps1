Write-Output "Starting setup"
$PI_IP = Read-Host "Enter board IP"
#$PI_IP = "192.168.0.64"

# Write-Output "Public certificates:"
# $KEY_FILES = Get-ChildItem -Path $env:USERPROFILE\.ssh\ -Name | Select-String -Pattern ".pub"
#
# for ($i = 0; $i -lt $KEY_FILES.Length; $i += 1) {
#     Write-Host $i $KEY_FILES[$i]
# }
#
# $SELECTED_FILE_INDEX = Read-Host "Which one to use"
# $SELECTED_FILE = $KEY_FILES[$SELECTED_FILE_INDEX]
#
# $PUBLIC_KEY = Get-Content $env:USERPROFILE\.ssh\$SELECTED_FILE

Write-Output "installing public certificate"
$PUBLIC_KEY = op read "op://Personal/raspberry_key/public key"

Write-Output $PUBLIC_KEY  | ssh pi@$PI_IP "mkdir .ssh ; cat >> .ssh/authorized_keys"

Write-Output "Change root password"
ssh pi@$PI_IP "passwd"
Write-Output "Copied files:"
scp ./rasbian_setup.sh pi@${PI_IP}:~/rasbian_setup.sh

Write-Output "Starting rasbian_setup.sh script"
ssh pi@$PI_IP "chmod +x ./rasbian_setup.sh && ./rasbian_setup.sh"
