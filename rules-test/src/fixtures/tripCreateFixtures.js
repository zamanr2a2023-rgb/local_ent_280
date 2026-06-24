import { roleFixtures } from './roleFixtures.js';

export const tripCreateFixtures = [
  {
    label: 'cliente',
    ...roleFixtures.client,
    shouldAllow: false
  },
  {
    label: 'condutor',
    ...roleFixtures.driver,
    shouldAllow: false
  },
  {
    label: 'manager',
    ...roleFixtures.manager,
    shouldAllow: false
  },
  {
    label: 'admin',
    ...roleFixtures.admin,
    shouldAllow: true
  }
];
