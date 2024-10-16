import { ApplicationConfig } from '@angular/core';
import {
  provideRouter,
  UrlSerializer,
  withComponentInputBinding
} from '@angular/router';

import { routes } from './app.routes';
import { provideHttpClient } from '@angular/common/http';
import { LowerCaseUrlSerializer } from './lower-case-url-serializer';

export const appConfig: ApplicationConfig = {
  providers: [
    {
      provide: UrlSerializer,
      useClass: LowerCaseUrlSerializer
    },
    provideRouter(routes, withComponentInputBinding()),
    provideHttpClient()
  ]
};
