# Changes

## 1.0.63 (game version 1.13.4.0)

### New
- **Human_player_husk** is now the default form of the Husk job: looks fully human and keeps the skin colour, hair
  and beard picked in character creation, so human clothing and skin mods work. Includes the
  `hh_humanhusksymbiosis` affliction and the client-side husk face overlay (`cl_humanHuskSkin.lua`).
- **Fused flesh** talent (`fusedflesh.lua`): a Human_player_husk wearing any diving suit turns into `Husk_player`.
  Max chosen talents in that tree raised from 5 to 6.
- **Hireable husks** at outposts (`hireables.lua`), using Hunter's Genetics - Base's hireable registry.
- Husk mute state is applied to newly created husk characters.

### Changed
- Only a fully fused husk can shift into a prowler.
- The prowler can no longer speak.
- Removed the extra damage from antipsychosis, antinarc, antidotes and antiparalysis.
- Scripts load with `require`; `cl_init.lua` removed.
- `HH:SetCanSpeak` is now a method; the mute chat command prints the new state on the server.

### Fixed
- Clown exosuit check used `not character.SpeciesName == "Husk_player"`, which was always false.
- Species checks in `shared.lua` no longer error on a nil character.

### Cleanup
- Debug prints removed. Many files had their line endings switched to CRLF.
