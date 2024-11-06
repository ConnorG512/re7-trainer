DLL injection for Resident Evil 7 Steam release. 

Compile: 
  - Clone the repo with git clone "git@github.com:ConnorG512/re7-trainer.git"
  - Build the project in the directory with "zig build -Dtarget=x86_64-windows --release=safe" (Built with Zig 0.13.0)

Using: 
  - Currently there is no standalone injector for this DLL. It will need to be injected with an injector, has been tested under Linux using cheat engine, However current 1.1 release has not yet been tested with Windows although I see no reason for it not to work.

Current patches:
  - Infinite Scrap (DLC Nightmare minigame)
  - Infinite ammo clip
  - infinite health
  - X Ray Item Vision
