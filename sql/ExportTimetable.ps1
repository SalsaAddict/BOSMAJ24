$Chrome = 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'

Start-Process $Chrome -Wait -ErrorAction Stop -ArgumentList `
    '--headless', `
    '--screenshot="C:\Users\I31759\source\repos\BOSMAJ24\src\assets\1-Thu.png"', `
    '--window-size=2000,1400', `
    'http://localhost:4200/timetable/thu'

Start-Process $Chrome -Wait -ErrorAction Stop -ArgumentList `
    '--headless', `
    '--screenshot="C:\Users\I31759\source\repos\BOSMAJ24\src\assets\2-Fri.png"', `
    '--window-size=2000,1400', `
    'http://localhost:4200/timetable/fri'

Start-Process $Chrome -Wait -ErrorAction Stop -ArgumentList `
    '--headless', `
    '--screenshot="C:\Users\I31759\source\repos\BOSMAJ24\src\assets\3-Sat.png"', `
    '--window-size=2000,1400', `
    'http://localhost:4200/timetable/sat'

Start-Process $Chrome -Wait -ErrorAction Stop -ArgumentList `
    '--headless', `
    '--screenshot="C:\Users\I31759\source\repos\BOSMAJ24\src\assets\4-Sun.png"', `
    '--window-size=2000,1400', `
    'http://localhost:4200/timetable/sun'

