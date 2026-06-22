import React from 'react';
import styles from './HomepageFeatures.module.css';

// Brand icons. They draw with `currentColor` (set to the emerald accent on the
// chip) so they adapt to light/dark themes automatically.
function ScopesIcon() {
  return (
    <svg width="30" height="30" viewBox="0 0 80 80" fill="none" aria-hidden="true">
      <rect x="10" y="10" width="60" height="60" rx="15" fill="none" stroke="currentColor" strokeOpacity="0.35" strokeWidth="5" />
      <rect x="22" y="22" width="36" height="36" rx="10" fill="none" stroke="currentColor" strokeOpacity="0.65" strokeWidth="5" />
      <rect x="33" y="33" width="14" height="14" rx="4" fill="currentColor" />
    </svg>
  );
}

function OrbitIcon() {
  return (
    <svg width="30" height="30" viewBox="0 0 80 80" fill="none" aria-hidden="true">
      <line x1="40" y1="40" x2="18" y2="18" stroke="currentColor" strokeOpacity="0.45" strokeWidth="4" />
      <line x1="40" y1="40" x2="62" y2="18" stroke="currentColor" strokeOpacity="0.45" strokeWidth="4" />
      <line x1="40" y1="40" x2="40" y2="64" stroke="currentColor" strokeOpacity="0.45" strokeWidth="4" />
      <rect x="29" y="29" width="22" height="22" rx="6" fill="currentColor" />
      <rect x="9" y="9" width="16" height="16" rx="5" fill="currentColor" fillOpacity="0.6" />
      <rect x="55" y="9" width="16" height="16" rx="5" fill="currentColor" fillOpacity="0.6" />
      <rect x="32" y="56" width="16" height="16" rx="5" fill="currentColor" fillOpacity="0.6" />
    </svg>
  );
}

function BlockIcon() {
  return (
    <svg width="30" height="30" viewBox="0 0 80 80" fill="none" aria-hidden="true">
      <polygon points="40,8 66,22 40,36 14,22" fill="currentColor" fillOpacity="0.35" />
      <polygon points="14,24 40,38 40,68 14,54" fill="currentColor" />
      <polygon points="66,24 40,38 40,68 66,54" fill="currentColor" fillOpacity="0.75" />
    </svg>
  );
}

const FeatureList = [
  {
    title: 'Route Management',
    Icon: ScopesIcon,
    description:
      'Take routing to the next level with the scope of resource routes organized by features.',
  },
  {
    title: 'Dependency Injection',
    Icon: OrbitIcon,
    description:
      "Keep dependencies modularized and guarantee memory deallocation when they're no longer needed.",
  },
  {
    title: 'Open Source',
    Icon: BlockIcon,
    description:
      'Created and maintained by the largest Flutter community in Brazil — free for everyone.',
  },
];

function Feature({Icon, title, description}) {
  return (
    <div className={styles.card}>
      <div className={styles.cardIcon}>
        <Icon />
      </div>
      <h3 className={styles.cardTitle}>{title}</h3>
      <p className={styles.cardText}>{description}</p>
    </div>
  );
}

export default function HomepageFeatures() {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className={styles.sectionHead}>
          <div className={styles.eyebrow}>Why Modular</div>
          <h2 className={styles.sectionTitle}>
            Everything your app structure needs
          </h2>
        </div>
        <div className={styles.grid}>
          {FeatureList.map((props) => (
            <Feature key={props.title} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
