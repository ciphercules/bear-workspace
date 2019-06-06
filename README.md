## Welcome
A place for bears
https://medium.com/@Andreas_cmj/how-to-setup-a-nice-looking-terminal-with-wsl-in-windows-10-creators-update-2b468ed7c326
https://medium.com/@ssharizal/hyper-js-oh-my-zsh-as-ubuntu-on-windows-wsl-terminal-8bf577cdbd97
https://blog.joaograssi.com/windows-subsystem-for-linux-with-oh-my-zsh-conemu/
https://gingter.org/2016/08/17/install-and-run-zsh-on-windows/

 prompt_context() {                                              
   if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then 
-    prompt_segment black default "%(!.%{%F{yellow}%}.)%n@%m"    
+         prompt_segment 5 15 "%(!.%{%F{yellow}%}.)%n@%m"        
   fi                                                            
 }  
