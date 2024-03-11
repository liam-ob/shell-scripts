@echo off

rem Set the path to the encrypted key file
set encrypted_key_file=path\to\encrypted_keys.7z

rem Prompt for the password to extract the keys
set /p password="Enter the password to extract the keys: "

rem Create a temporary directory to extract the keys
set "tmp_dir=%TEMP%\tmp_%RANDOM%"
mkdir "%tmp_dir%"

rem Extract the keys from the .7z file
7z x "%encrypted_key_file%" -o"%tmp_dir%" -p"%password%" > nul

rem Set the AWS instance details
set aws_instance=user@instance_ip_or_hostname

rem Connect to the AWS instance using the extracted key
ssh -i "%tmp_dir%\id_rsa" %aws_instance%

rem Clean up the temporary directory
rd /s /q "%tmp_dir%"

echo Keys have been securely deleted.
pause