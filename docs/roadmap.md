# Roadmap

We are in a proof of concept phase right now, so far we have achieved the followings:
 - we know *it's possible* to run HW accelerated games on Docker
 - we have working environments in `Debian` and `Unraid` with and without a GPU


We would like to achieve the followings:
 - make a general set of Docker containers that can run any GUI app (as long as it can run on Docker).
 - make a *launcher app* that will let users start/stop other GUI containers *easily*.
   - This will be possible by passing the Docker socket.
 - support as much platforms as we can.
 - make a great documentation so that anybody can understand and learn from this project.