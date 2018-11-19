# Rmate port
export RMATE_PORT=<port_rmate>
export RMATE_HOST=localhost

alias prince='sshpass -f ~/prince.pwd ssh prince'
alias jpprince='sshpass -f ~/prince.pwd ssh -N -L localhost:8888:localhost:<port_jupyter> <net_id>@prince'