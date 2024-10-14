import { DatePipe } from '@angular/common';
import { Directive, ElementRef, Input, numberAttribute } from '@angular/core';
import { toTime } from './itimetable';

@Directive({
  selector: '[time]',
  providers: [DatePipe],
  standalone: true
})
export class TimeDirective {
  @Input({ alias: 'time', required: true, transform: numberAttribute })
  hour!: number;
  constructor(
    private readonly el: ElementRef<HTMLTableCellElement>,
    private readonly datePipe: DatePipe
  ) {
    el.nativeElement.classList.add('time');
  }
  ngOnInit() {
    let start = this.datePipe.transform(toTime(this.hour), 'HH:mm')!,
      end = this.datePipe.transform(toTime(this.hour + 1), 'HH:mm')!;
    this.el.nativeElement.innerHTML = `${start} &ndash; ${end}`;
  }
}
