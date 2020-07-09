# Deploy e test #1

## Building

Compila nella directory `local_builds` che è ignorata da Git
per via del contenuto di `~/.config/git/ignore`.

Dalla directory radice del repository dare questi comandi:

```
autoreconf -f -i
SRCDIR=$(pwd)
mkdir -p local_builds
cd local_builds
export VALAFLAGS="-g"
export CFLAGS="-g -O0"
export LDFLAGS="-g"
${SRCDIR}/configure
make
```

Si ottiene l'eseguibile `sys_ntkd_test1`.

## Testing

Il test consiste nel simulare questo scenario:

```
          Nodo 123                          Nodo 456          
          --------                          --------          
   eth1  |        |  eth2            eth1  |        |  eth2   
  ---====|        |====----------------====|        |====-----
         |        |                        |        |         
          --------                          --------          
```

Nella directory dove si trova l'eseguibile, aprire
5 terminali.

Sul terminale #1 dare il comando `eth_domain -i 123_eth1 -v`.  
Il processo resta appeso.

Sul terminale #2 dare il comando `eth_domain -i 456_eth2 -v`.  
Il processo resta appeso.

Sul terminale #3 dare il comando `eth_domain -i 123_eth2 -i 456_eth1 -v`.  
Il processo resta appeso.

Sul terminale #4 dare il comando `./sys_ntkd_test1 -p 123 -i eth1 -i eth2`.  
Il processo produce alcuni output.

Sul terminale #5 dare il comando `./sys_ntkd_test1 -p 456 -i eth1 -i eth2`.  
Il processo produce alcuni output.

```
eth_domain -i 123_eth1 -v
eth_domain -i 456_eth2 -v
eth_domain -i 123_eth2 -i 456_eth1 -v
./sys_ntkd_test1 -p 123 -i eth1 -i eth2
./sys_ntkd_test1 -p 456 -i eth1 -i eth2
```

***

