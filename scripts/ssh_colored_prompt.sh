#! /bin/sh

ssh -t inwatec@192.168.0.99 "
echo 'source ~/.bashrc' > /tmp/mads_bashrc;
echo 'ip a
echo 'if export PS1=\"\$(echo \"\$PS1\" | sed \"s/01;32/00;31/g\" )\"' >> /tmp/mads_bashrc;
echo 'echo test > /tmp/lmao' >> /tmp/mads_bashrc;
bash --rcfile /tmp/mads_bashrc
"
