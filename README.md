# Basys
## <b>B</b>idirectional <b>asy</b>nchronou<b>s</b> network. </br>

Basys implements an abstract layer for networks which require bidirectional communication between clients and servers. Basys manages connections in such a way that sending and receiving data can be performed independently and simultaneously.

Each Basys connection runs its own incoming data loop which processes received data asynchronously. Every received data is processed in a separate thread. Communication between client and server are equivalent in both directions. 

Basys is network foundation for [Seamless](http://smalltalkhub.com/#!/~Pharo/Seamless). 

You can find documentation [here](https://ci.inria.fr/pharo-contribution/view/Books/job/PharoBookWorkInProgress/lastSuccessfulBuild/artifact/book-result/BasysNetwork/BasysNetwork.pdf)
