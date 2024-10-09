import { Directive, ElementRef, Input, OnInit } from '@angular/core';

@Directive({
  selector: '[appBreak]',
  standalone: true
})
export class BreakDirective implements OnInit {
  @Input() appBreak?: string;
  constructor(private readonly el: ElementRef<HTMLTableCellElement>) {
    el.nativeElement.classList.add(
      'table-secondary',
      'text-uppercase',
      'text-muted'
    );
  }
  ngOnInit() {
    this.el.nativeElement.innerText = this.appBreak ?? 'Break';
  }
}
