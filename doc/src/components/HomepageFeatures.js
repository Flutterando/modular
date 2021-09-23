import React from 'react';
import clsx from 'clsx';
import styles from './HomepageFeatures.module.css';

const FeatureList = [
  {
    title: 'Route Management',
    Svg: require('../../static/img/undraw_route.svg').default,
    description: (
      <>
        Modular grow up the system route to the next level, working with the scope of
        resource routes by features.
      </>
    ),
  },
  {
    title: 'Dependency Injection',
    Svg: require('../../static/img/undraw_di.svg').default,
    description: (
      <>
       keep dependencies in a modularized way and guarantees memory deallocation when it is no longer needed.
      </>
    ),
  },
  {
    title: 'Open source',
    Svg: require('../../static/img/undraw_community.svg').default,
    description: (
      <>
        Created and maintained by the largest Flutter community in Brazil and free for everyone!
      </>
    ),
  },
];

function Feature({Svg, title, description}) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        <Svg className={styles.featureSvg} alt={title} />
      </div>
      <div className="text--center padding-horiz--md">
        <h3>{title}</h3>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures() {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
