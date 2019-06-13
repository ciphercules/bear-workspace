## Setting Up a Bear Workspace

This workspace is optimized for bear development. If you're a human, this just
isn't for you. Feel free to try, but a lot of what goes on in this repo won't
make any sense, and you're going to feel lost, a little scared, and very very
hungry.

If you're a bear, congratulations, you good-looking animal! Follow these steps to
get a workspace that works well, looks great, and is up to bear standards.

This will give you a few things:
- Hyper.js
- Ubuntu WSL
- neovim
- nvim config for working with go
- python3
- git

## Install Ubuntu on Windows Subsystem linux
This is taken from this website: https://docs.microsoft.com/en-us/windows/wsl/install-win10
1. Open PowerShell as Administrator and run:
```
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
```
2. Restart your computer when prompted.
3. Install Ubuntu for Windows. Just go to the Microsoft store, you cute little creature
4. Launch Ubuntu, and  go through the unix user set up instructions
5. Do you have an ugly computer name? Let's go fix that

![Ugly Computer Name](images/ugly_computer_name.png?raw=true "Ugly Computer Name")

*Pictured above: ugly computer name*

## Fix Ugly Computer Name
1. Search for "About your PC"
2. Click "Rename this PC"
3. Type in your sexy new name
4. Restart your computer

## Set Up HyperJS
Oh my good, you are adorable. Go get that Hyper JS, you fluffy son of a bitch. 

1. Install HyperJS: https://hyper.is/


A place for bears
https://medium.com/@Andreas_cmj/how-to-setup-a-nice-looking-terminal-with-wsl-in-windows-10-creators-update-2b468ed7c326
https://medium.com/@ssharizal/hyper-js-oh-my-zsh-as-ubuntu-on-windows-wsl-terminal-8bf577cdbd97
https://blog.joaograssi.com/windows-subsystem-for-linux-with-oh-my-zsh-conemu/
https://gingter.org/2016/08/17/install-and-run-zsh-on-windows/

 ```diff
 prompt_context() {                                              
   if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
-    prompt_segment black default "%(!.%{%F{yellow}%}.)%n@%m"    
+    prompt_segment 5 15 "%(!.%{%F{yellow}%}.)%n@%m"        
   fi                                                            
 }
 ```
