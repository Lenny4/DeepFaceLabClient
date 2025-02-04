# Changelog

## [Unreleased]

### Added

### Fixed

### Changed

### Removed

## [0.4.4] - 2024-10-21

### Fixed

- Can click the links on the releases.

## [0.4.3] - 2024-10-21

### Fixed

- Fix GPU not showing up on Windows, thanks to [Lumerica](https://github.com/Lenny4/DeepFaceLabClient/issues/73#issuecomment-2424318499).

## [0.4.2] - 2023-09-16

### Fixed

- Fix release windows.

## [0.4.1] - 2023-09-16

### Added

- Add release for ubuntu 24.


## [0.4.0] - 2023-09-16

### Changed

- On Linux source files are no longer downloaded from [DeepFaceLab](https://github.com/iperov/DeepFaceLab) as project as been shutdown by github.

## [0.3.0] - 2023-06-20

### Added

- Add self promotion on the home screen and help screen
- Add more info on release (download count, release date)

### Changed

- Copy `msvcp140.dll` `vcruntime140.dll` and `vcruntime140_1.dll` directly from the github host (
  windows)

see `Copy dll files` in `.github/workflows/release.yml`
- Change screen `Tutorials` to `Help` and add more useful links

## [0.2.0] - 2023-06-18

### Added

- Show the size of all folders in workspace

## [0.1.2] - 2023-06-14

Note: need to install it manually from the github if on windows.

### Fixed

- Fix the bug on windows which erased DeepFaceLabClient when trying to install a release (/!\ the
  bug is still present in earlier versions)

## [0.1.1] - 2023-06-13

Note: on this version installing another release doesn't work (on windows), you need to install it
manually from the github.

### Fixed

- Fix download Miniconda3-latest-Linux-x86_64.sh with no certificate

## [0.1.0] - 2023-06-12

Note: on this version installing another release doesn't work (on windows), you need to install it
manually from the github.

### Added

- Install requirements (linux)
- Install Deepfacelab
- Create workspaces
- Delete workspaces
- Filesystem navigation (rename, delete, navigate in folders) + Shortcuts
- Show GPUs of the host
- Can change theme appearance (dark theme, light theme)
- Launch Deepfacelab scripts
- See and install releases
