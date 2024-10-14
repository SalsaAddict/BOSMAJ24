import { Component, ViewEncapsulation } from '@angular/core';
import { RouterOutlet, RouterLink, RouterLinkActive } from '@angular/router';
import { SystemService } from './system.service';
import { environment } from '../environments/environment';
import { APP_BASE_HREF } from '@angular/common';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, RouterLink, RouterLinkActive],
  providers: [{ provide: APP_BASE_HREF, useValue: environment.appBaseUrl }],
  templateUrl: './app.component.html',
  encapsulation: ViewEncapsulation.None
})
export class AppComponent {
  constructor(readonly auth: SystemService) {}
}
