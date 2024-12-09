
# voice-training-app

![Test Badge](https://github.com/jorbDehmel/voice-training-app/actions/workflows/ci-test.yml/badge.svg)

Target platform(s):
- Android (WIP)
- Chrome (Better for development & testing)

To build and launch the development Docker container, just run
```sh
make run
```
from this directory. To run via `flutter` on your machine's
Google Chrome, run
```sh
flutter run -d chrome
```
from `./app/`. Similarly, to run the automated unit tests, run
```sh
flutter test
```
from `./app/`. The most relevant directories are `./app/lib` and
`./app/test` for building and testing the app, respectively.

# Future Work

- Multithreading
    - Currently UI and computation are on 1 thread
    - It would run better if all the work was done on a separate
        thread from the UI
- Passthrough page
    - Currently only the analysis page is implemented
    - The passthrough page has been sidelined in the meantime,
        and does not currently work
- Automated widget testing
    - Currently only computational unit testing it automated
    - UI testing is done by humans
    - It would be better if the GUI was also automatically unit
        tested
- Control flow simplification
    - Currently the microphone data is stored in an intermediate
        buffer, and separate timers are started to update the
        passthrough or analysis pages
    - It would be better if the microphone's "on yield" function
        directly did the work, without using a buffer
    - Could be done by switching lambda functions depending on
        the desired work in the Voice Analyzer class

# License

This software was developed at Colorado Mesa University under
the MIT license. See the app's `info` page for more details.
