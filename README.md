# Basys

[![GitHub release](https://img.shields.io/github/release/pharo-ide/Basys.svg)](https://github.com/pharo-ide/Basys/releases/latest)
[![Unit Tests](https://github.com/pharo-ide/Basys/actions/workflows/tests.yml/badge.svg)](https://github.com/pharo-ide/Basys/actions/workflows/tests.yml)

[![Pharo 7.0](https://img.shields.io/badge/Pharo-7.0-informational)](https://pharo.org)
[![Pharo 8.0](https://img.shields.io/badge/Pharo-8.0-informational)](https://pharo.org)
[![Pharo 9.0](https://img.shields.io/badge/Pharo-9.0-informational)](https://pharo.org)
[![Pharo 10](https://img.shields.io/badge/Pharo-10-informational)](https://pharo.org)
[![Pharo 11](https://img.shields.io/badge/Pharo-11-informational)](https://pharo.org)

## <b>B</b>idirectional <b>asy</b>nchronou<b>s</b> network. </br>

Basys implements an abstract layer for networks which require bidirectional communication between clients and servers. Basys manages connections in such a way that sending and receiving data can be performed independently and simultaneously.

Each Basys connection runs its own incoming data loop which processes received data asynchronously. Every received data is processed in a separate thread. Communication between client and server are equivalent in both directions. 

Basys is network foundation for [Seamless](http://smalltalkhub.com/#!/~Pharo/Seamless). 

You can find documentation [here](https://github.com/SquareBracketAssociates/Booklet-Infrastructure)
