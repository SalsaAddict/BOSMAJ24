const fs = require('node:fs');
const UTF8_BOM = '\u{FEFF}';

let filename = '../src/assets/timetable.json';
let content = fs.readFileSync(filename).toString();
if (content.startsWith(UTF8_BOM)) {
  content = content.substring(UTF8_BOM.length);
}
let timetable = JSON.parse(content);

const activities = [
  {
    AreaId: 'P',
    Day: 'Thu',
    Hour: 16,
    Hours: 3,
    Title: 'Pool Party',
    Category: 'Party'
  },
  {
    AreaId: 'P',
    Day: 'Fri',
    Hour: 15,
    Hours: 3,
    Title: 'Pool Party',
    Category: 'Party'
  },
  {
    AreaId: 'P',
    Day: 'Sat',
    Hour: 15,
    Hours: 3,
    Title: 'Pool Party',
    Category: 'Party'
  },
  {
    AreaId: 'P',
    Day: 'Sun',
    Hour: 14,
    Hours: 2,
    Title: 'Pool Party',
    Category: 'Party'
  },
  {
    AreaId: 'P',
    Day: 'Sun',
    Hour: 16,
    Hours: 4,
    Title: 'Mega Pool Party',
    Subtitle: 'Dancing',
    Description: 'Animations &amp; Craziness',
    Category: 'Party'
  },
  {
    AreaId: 'M',
    Day: 'Sat',
    Hour: 14,
    Hours: 1,
    Title: 'Tech Rehearsal',
    Subtitle: '(Performers Only)',
    Category: 'Performance'
  },
  {
    AreaId: 'M',
    Day: 'Sat',
    Hour: 18,
    Hours: 2,
    Title: 'Shows',
    Category: 'Performance'
  },
  {
    AreaId: 'S',
    Day: 'Fri',
    Hour: 17,
    Hours: 1,
    Title: 'Jack &amp; Jill',
    Subtitle: 'Registration &amp; Sign-Up',
    Description: '(Competitors Only)',
    Category: 'Performance'
  },
  {
    AreaId: 'M',
    Day: 'Fri',
    Hour: 18,
    Hours: 2,
    Title: 'Jack &amp; Jill',
    Subtitle: 'Competition',
    Category: 'Performance'
  }
];

timetable.Items.push(...activities);

timetable.Days.forEach((day) => {
  let parties = [
    {
      Day: day.Day,
      AreaId: 'M',
      Hour: 22,
      Hours: 4,
      Title: 'Bachata Party',
      Subtitle: '100% Bachata',
      Category: 'Party'
    },
    {
      Day: day.Day,
      AreaId: 'M',
      Hour: 2,
      Hours: 1,
      Title: '50/50 Party',
      Subtitle: 'Bachata &amp; Salsa',
      Category: 'Party'
    },
    {
      Day: day.Day,
      AreaId: 'R',
      Hour: 22,
      Hours: 4,
      Title: 'Salsa Party',
      Subtitle: '100% Salsa',
      Category: 'Party'
    },
    {
      Day: day.Day,
      AreaId: 'L',
      Hour: 22,
      Hours: 3,
      Title: 'Latino Party',
      Subtitle: 'Reggaeton &amp; More',
      Category: 'Party'
    }
  ];
  timetable.Items.push(...parties);
});

timetable.Categories = [
  'Bachata',
  'Salsa',
  'Other',
  'Party',
  'Performance'
];

fs.writeFileSync(filename, JSON.stringify(timetable), { encoding: 'utf8' });
