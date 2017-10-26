FROM microsoft/dotnet

#==========================
# TODO: Use desired values
#==========================
ENV username dev
ENV password pass
ENV rootpassword word
ENV DOTNET_CLI_TELEMETRY_OPTOUT 1

#============
# Add a user
# 1) First add a user and set user's shell to bash and create a directory for user in the /home folder
# 2) Next set the user's password
# 3) Then add the user to the `sudo` group so the user can use the `sudo` command
#============
RUN useradd -ms /bin/bash $username
RUN echo $username:$password | chpasswd
RUN adduser $username sudo

RUN apt-get update

#=====================
# Updates for debconf
# Prevent message 'debconf: unable to initialize frontend: Dialog'
# Prevent message 'debconf: delaying package configuration, since apt-utils is not installed'
#=====================
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get install -y --no-install-recommends apt-utils

#================
# Basic software
#================
RUN apt-get install -y sudo
RUN apt-get install -y curl
RUN apt-get install -y nano
RUN apt-get install -y htop

#===========================================================================
# Install Programming Languages. Add or remove languages as desired.
# Note: C and C++ are installed above and do not need to be listed here.
#===========================================================================

#== Init a dotnet core console project
RUN su -c "dotnet new console -o /home/$username/" $username

#===========================================================================
# End of Languages section
#===========================================================================

#===================
# Set root password
#===================
RUN echo root:$rootpassword | chpasswd

#================
# Set ENTRYPOINT
# Copy entry_point file and make it executable.
#=================
COPY ./entry_point.sh /
RUN chmod 744 /entry_point.sh
ENTRYPOINT ["/entry_point.sh"]

#==================
# Set default user
# 1) Set the default user when the container starts
# 2) Set the default directory to load when container starts
#==================
USER $username
WORKDIR /home/$username
