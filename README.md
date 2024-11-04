DLL injection for Resident Evil 7 Steam release. 

Compile: 
  - Clone the repo with git clone "git@github.com:ConnorG512/re7-trainer.git"
  - Build the project in the directory with "zig build --release=fast -Dtarget=x86_64-windows" (Built with Zig 0.13.0)

Using: 
  - Currently there is no standalone injector for this DLL. It will need to be injected with an injector, has been tested under Linux using cheat engine, However current 1.1 release has not yet been tested with Windows although I see no reason for it not to work.

Code for inifinite scrap (DLC Nightmare minigame) as well as infinite clip will be automatically written on injection, there is no current way to turn it off other than to quit the game and restart. 
