function Write-Figlet() 
{ 
    Param($message, $font)

    if(!$message) { $message = "$input" }

    figlet "$message" "$font"
}

#figlet "test"
#Write-Figlet -message "test"
#"test" | Write-Figlet 

