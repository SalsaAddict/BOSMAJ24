import { Directive, ElementRef, Input } from '@angular/core';

@Directive({
  selector: '[appTimetableClosed]',
  standalone: true
})
export class TimetableClosedDirective {
  @Input() closedText = 'Closed';
  constructor(private readonly el: ElementRef<HTMLTableRowElement>) {
    this.el.nativeElement.classList.add(
      'text-uppercase',
      'text-muted',
      'small'
    );
  }
  ngOnInit() {
    this.el.nativeElement.innerText = this.closedText;
  }
}
