<!--
  title: First Beat Media ~ Cozy development on Windows
  theme: united
-->

Setup Development Environment
=============================

Emphasis on Windows, because, after all, is is the most used OS in the world.

1. Install [Git for Windows][1]. It will provide you with SSH, also.
2. Install [VirtualBox][2].
3. Finally, install [Vagrant][3]. With a couple of PATH commands, it will provide you with Ruby
   environment.
4. Improve command console, a lot, with [clink][4] and [ConEmu][5]

[1]: http://code.google.com/p/msysgit/downloads/list?q=full+installer+official+git
[2]: https://www.virtualbox.org/wiki/Downloads
[3]: http://vagrantup.com/
[4]: http://code.google.com/p/clink/ "Bringing Bash's Windows"
[5]: http://code.google.com/p/conemu-maximus5/ "Windows Console Emulator"

Now you have SSH, Git, Ruby and Vagrant. Plus VirtualBox as mandatory for Vagrant.

## Get us some basic tools

Before anything, I need some basic tools like wget, unzip and sed. But, I don't need the extra
baggage of cygwin and the likes - I just want couple of small .exe file.

Install `wget` by copy-pasting this in command line (cmd.exe). Then, install a nifty tool -
[Rapid Environment Editor][1] (`ree`) for editing environment variables (mostly PATH).

    mkdir "%ProgramFiles%\Tools"
    cd /D "%ProgramFiles%\Tools"

    @powershell -NoProfile -ExecutionPolicy unrestricted -Command "(new-object net.webclient).DownloadFile('http://users.ugent.be/~bpuype/wget/wget.exe', \"%ProgramFiles%\\Tools\\wget.exe\"")

    wget -nc http://gnuwin32.sourceforge.net/downlinks/unzip.php
    for /f "tokens=*" %f in ('dir unzip-*.exe /B') do @(start /wait %f /silent /dir="%ProgramFiles%\Tools" /noicons /components="bin" /tasks="" && del /Q unzip-*.exe)

    set PATH=%ProgramFiles%\Tools;%ProgramFiles%\Tools\bin;%PATH%

    wget -nc http://gnuwin32.sourceforge.net/downlinks/sed.php
    for /f "tokens=*" %f in ('dir sed-*-setup.exe /B') do @(start /wait %f /silent /dir="%ProgramFiles%\Tools" /noicons /components="bin" /tasks="" && del /Q sed-*-setup.exe)

    wget http://www.rapidee.com/download/RapidEE.zip
    unzip RapidEE.zip RapidEE.exe -d "%ProgramFiles%\Tools"
    del RapidEE.zip && rename "%ProgramFiles%\Tools\RapidEE.exe" ree.exe

    "%ProgramFiles%\Tools\ree" -i -c -m PATH "%ProgramFiles%\Tools;%ProgramFiles%\Tools\bin"

Now, we can use these couple of utils.
Check if everything is ok with `where wget unzip sed ree`.

[1]: http://www.rapidee.com/en/command_line "Rapid Environment Editor"

## Install VirtualBox

VirtualBox is needed for Vagrant, among others.

Prepare directory to download installation files.

    mkdir "%TEMP%\Download"
    cd /D "%TEMP%\Download"

Download and execute installers. This will *install the latest versions*.

    for /f "tokens=*" %f in ('wget -q http://download.virtualbox.org/virtualbox/LATEST.TXT -O -') do @(set _LASTVER=%f)

    wget -O - "http://download.virtualbox.org/virtualbox/%_LASTVER%/" 2>nul | ^
    sed -n "s/.*A HREF=\x22\(.*\)\.exe\x22 NAME.*/http:\/\/download\.virtualbox\.org\/virtualbox\/%_LASTVER%\/\1\.exe/p" | ^
    wget -i - -O latest-virtualbox.exe

    start /wait latest-virtualbox.exe -silent && echo VirtualBox Installed

## Install Vagrant

We are trying to install the latest versions, always.

    wget http://downloads.vagrantup.com/ -O - 2>nul | ^
    sed -n "0,/.*\(http:\/\/downloads\.vagrantup\.com\/tags\/v.*\)\x22.*/s//\1/p" | ^
    wget -i - -O - 2>nul | ^
    sed -n "0,/.*type\-msi\x22 href\=\x22\(.*\)\x22.*/s//\1/p" | ^
    wget -i - -O latest-vagrant.exe

    start /wait msiexec /i latest-vagrant.exe /passive INSTALLDIR="c:\" && echo Vagrant Installed

    exit

I closed this command line session on purpose. The reason: Vagrant adds itselt to the path, but,
thats not propagated to current session. So, just close current one and start a new one (cmd.exe)

## Maybe you have Git?

Probably you already are using Git. But, just in case you don't, lets go through unattended (silent)
setup process.

    wget --no-check-certificate https://code.google.com/p/msysgit/downloads/list -O - 2>nul | ^
    sed -n "0,/.*\(\/\/msysgit.googlecode.com\/files\/Git-.*\.exe\).*/s//http:\1/p" | ^
    wget -i - -O latest-git.exe

    start /wait latest-git.exe /silent /components="icons,icons\quicklaunch,ext,ext\cheetah,assoc,assoc_sh" /tasks="" && echo Git Installed

I forced Git to add itself to path variable, install Git-Cheetah, use OpenSSH and not Putty's Plink,
etc. Installation directory I left default. If you have some other wishes, please install manually.

## Set environment variables

Add VirtualBox to path - we want VBoxManage to work anywhere. Not that we need it.

    set HOME=%USERPROFILE%
    ree -u HOME "%USERPROFILE%"

    ree -a -c -m PATH "%VBOX_INSTALL_PATH%"

    set VAGRANT_HOME=%HOME%\.vagrant.d
    ree -u VAGRANT_HOME "%VAGRANT_HOME%"

    echo gem: --no-ri --no-rdoc > %PROGRAMDATA%\gemrc

We want to know where Git is installed. So we try with path, and if it's not in the path, try by
digging in the registry (and looking for Git-Cheetah traces). Let's find out where it is:

    for %i in (git.exe) do @(set _TMP=%~$PATH:i)
    if defined _TMP (for /f "tokens=*" %f in ('echo "%_TMP%" ^| sed -n "s/\(.*\)\x5c\x5c\S\S\S\x5c\x5cgit\.exe/\1/p"') do @(set _TMP=%f))

    if not defined _TMP (for /f "tokens=*" %f in ('reg query "HKEY_CURRENT_USER\Software\Git-Cheetah" -v "PathToMsys" ^| sed -n "s/.*REG_SZ\s*\(.*\)/\1/p"') do @(set _TMP=%f))

    pushd "%_TMP%"
    set GIT_INSTALL_ROOT=%CD%
    popd

    ree -u GIT_INSTALL_ROOT "%GIT_INSTALL_ROOT%"

    set PATH=%GIT_INSTALL_ROOT%\bin;%GIT_INSTALL_ROOT%\cmd;%PATH%
    ree -i -c -m PATH "%GIT_INSTALL_ROOT%\bin;%GIT_INSTALL_ROOT%\cmd"

There is some strange bug saying `WARNING: terminal is not fully functional` warning when starting
Git log or diff commands. The solution is that environment variable `TERM` must be set to any valid
value. If not set, on Windows it defaults to `winansi`, and that's the one Git doesn't like. So I
must set something else - any of the following: `cygwin`, `vt100`, `msys`, `linux`.

    set TERM=linux
    ree -m TERM "%TERM%"

I don't want to have any Ruby environment. So, don't add `vagrant\embedded\bin\` to the path, at
all. But, in any case, set some variables, if you ever install some gem.

    for /f "tokens=*" %f in ('vagrant gem env gemhome') do @(set _CURGEM=%f)

    set _TMP=c:\vagrant\embedded\lib\ruby\gems
    for /f "tokens=*" %f in ('dir "%_TMP%" /B /A:D') do @(set _VAGGEM=%_TMP%\%f)

    set GEM_HOME=%VAGRANT_HOME%\gems
    set GEM_PATH=%GEM_HOME%;%_CURGEM%;%_VAGGEM%

    ree -u GEM_HOME "%GEM_HOME%"
    ree -u GEM_PATH "%GEM_PATH%"

We need to close console, because some environment variables are not propagated, because they are
in a System environment. So, again, start the command prompt.

## Install Enhancements

### DNS forwarder for Windows / Dnsmasq for Windows

The best one is Acrylic. It's lightweight and runs as a service. Install with:

    wget http://sourceforge.net/projects/acrylic/files/latest/download -O acrylic.exe
    start /wait acrylic.exe /S /D=%ProgramFiles%\DNSProxy && echo DNS Proxy installed.

Set couple of variables:

    set DNSPROXY_INSTALL_ROOT=C:\Program Files\DNSProxy
    ree -m DNSPROXY_INSTALL_ROOT "%DNSPROXY_INSTALL_ROOT%"

    set DNSPROXY_HOSTS=%DNSPROXY_INSTALL_ROOT%\AcrylicHosts.txt
    ree -m DNSPROXY_HOSTS "%DNSPROXY_HOSTS%"

By default, Acrylic uses OpenDNS servers, but I prefer Google's ones. So, change that:

    sed -i.bak -e "s/^\(PrimaryServerAddress\)=.*$/\1=8.8.8.8/g" ^
        -e "s/^\(SecondaryServerAddress\)=.*$/\1=8.8.4.4/g" ^
        "%DNSPROXY_INSTALL_ROOT%\AcrylicConfiguration.ini"

Set our proxy as default DNS server for our machine. This will find the first interface named like
this, and set DNS as it should be:

    netsh interface ip set dns "Local Area Connection"          static 127.0.0.1
    netsh interface ip set dns "Wireless Network Connection"    static 127.0.0.1

Creating a symlink definitly not working:

    ren "%DNSPROXY_INSTALL_ROOT%\AcrylicHosts.txt" AcrylicHosts.original.txt
    mklink /H "%DNSPROXY_INSTALL_ROOT%\AcrylicHosts.txt" "%SystemRoot%\System32\drivers\etc\hosts"

Restart DNS service:

    net stop AcrylicController & net start AcrylicController

Vagrant TODO:
    First in Ruby create lines like for hosts file (with VM UUID). Then compare if anything changed.
    If it is, obviosly change that in file AcrylicHosts.txt, and restart service.

I can precompile Acrylic with [Delphi 10 Lite][1]. I wrote an email to author, but if he doesn't do
anything, I prepared eevrything to make a patch.

[1]: http://www.igor-thief.pisem.net/delphi/Delphi10Lite/readme.txt "Delphi 10 Lite"

### Git-flow

It needs some files from Linux Utils package, so install it:

    wget -nc http://gnuwin32.sourceforge.net/downlinks/util-linux-ng.php
    for /f "tokens=*" %f in ('dir util-linux-ng-*-setup.exe /B') do @(start /wait %f /silent /dir="%ProgramFiles%\Tools" /noicons /components="bin" /tasks="" && del /Q util-linux-ng-*-setup.exe)

Download `getopt.exe` from `Binaries` and copy it to `Git\bin` directory.
We already have out variable: `%GIT_INSTALL_ROOT%`, so we will use it:

    cd /D "%GIT_INSTALL_ROOT%"
    git clone --recursive git://github.com/nvie/gitflow.git

And execute setup:

    cd gitflow/contrib
    msysgit-install.cmd "%GIT_INSTALL_ROOT%"

### Nano editor

It's the favourite small and fast linux-world editor. I like it, for basic editing, and I want it on
Windows, too.

    wget http://www.nano-editor.org/download.php -O - 2>nul | ^
    sed -n "0,/.*href=\x22\(http:\/\/www\.nano-editor\.org\/dist\/.*\/nano-.*\.zip\)\x22.*/s//\1/p" | ^
    wget -i - -O latest-nano.zip

    unzip -o latest-nano.zip *.dll *.exe -d "%ProgramFiles%\Tools" && del latest-nano.zip

### Vagrant plugins

Install them easily. Search for more plugins on a [RubyGems site][1].

    vagrant gem install vagrant-hostmaster
    vagrant gem install vagrant-vbguest
    vagrant gem install vagrant-list

You are noticing that Vagrant has installed embedded Ruby environment, and RubyGems with it. You
shouldn't use it directly, but you can through Vagrant subcommands.

[1]: http://rubygems.org/ "RubyGems.org | your community gem host"

### Vagrant Patch

Vagrant still has a bugs, specially for Windows. So sometimes we need to patch some files to help
him work. This pach is very important because I really like `vagrant ssh` command, and by default,
it doesn't work in Windows.

Find the location of a file

    for /f "tokens=*" %f in ('where /R "c:\vagrant" "ssh.rb" ^| grep "embedded\\\lib\\\ruby\\\gems\\\.*\\\gems\\\vagrant.*\\\lib\\\vagrant\\\ssh.rb"') do @(set _TMP=%f)

And patch that `ssh.rb` file

    (
    echo/57a58
    echo/^> =begin
    echo/65a67,71
    (echo/^> )
    echo/^> =end
    (echo/^> )
    echo/^>       which = Util::Platform.windows? ? "where ssh >NUL 2>&1" : "which ssh >/dev/null 2>&1"
    echo/^>       raise Errors::SSHUnavailable if !Kernel.system^(which^)
    ) >vagrant-ssh-windows-patch.diff

    patch -i vagrant-ssh-windows-patch.diff "%_TMP%"

And remove residues.

    del vagrant-ssh-windows-patch.diff

SSH in Vagrant will now work as supposed to:

    vagrant ssh


## Console

The default command console in Windows is not up to the task. With two little tools, I will try to
improve it. Every hacker-in-heart will love these two cuties.


### Clink

Bringing Bash's to Windows. You'll love it.

- Improved command line history that persists across sessions.
- Searchable history (Ctrl-R and Ctrl-S)
- Traditional Bash clear screen (Ctrl-L) and exit shortcuts (Ctrl-D).
- Scrollable command window using PgUp/PgDown keys.
- Paste from clipboard (Ctrl-V or R-Click)

By default, Clink installs itself  in `C:\Program Files (x86)\clink`, and I will leave it there.

##### Note on one dependency

For some of it's functionality clink needs Microsoft Visual C++ 2010 Redistributable Package.
So let's assure that it's present.

    wget http://download.microsoft.com/download/C/6/D/C6D0FD4E-9E53-4897-9B91-836EBA2AACD3/vcredist_x86.exe
    start /wait vcredist_x86.exe /passive /norestart && echo Installed: Microsoft Visual C++ 2010 SP1 Redistributable Package (x32)

Only now we can proceed with silent install procedure of `clink` itself:

    wget --no-check-certificate http://code.google.com/p/clink/downloads/list -O - 2>nul | ^
    sed -n "0,/.*\(\/\/clink.googlecode.com\/files\/clink_.*setup\.exe\).*/s//http:\1/p" | ^
    wget -i - -O latest-clink.exe

    start /wait latest-clink.exe /S && echo Clink installed. Enjoy.

### ConEmu

Command prompt will already be more pleasent place. But I want more, so I will install ConEmu. Great
tool, something that you'll as much as you like Total Commander.

    wget --no-check-certificate http://code.google.com/p/conemu-maximus5/downloads/list -O - 2>nul | ^
    sed -n "0,/.*\(\/\/conemu-maximus5.googlecode.com\/files\/ConEmuSetup.*\.exe\).*/s//http:\1/p" | ^
    wget -i - -O latest-conemu.exe

    start /wait latest-conemu.exe /p:x64 /quiet ADDLOCAL="FConEmuGui,FConEmuGui64,ProductFeature,FConEmuBase32,FConEmuBase,FConEmuBase64,FConEmuCmdExt,FConEmuDocs,FCEShortcutStart"&& echo ConEmu installed.

That was it.







