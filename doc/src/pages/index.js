import React from 'react';
import clsx from 'clsx';
import Layout from '@theme/Layout';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import styles from './index.module.css';
import HomepageFeatures from '../components/HomepageFeatures';

function HomepageHeader() {
  return (
    <header className={styles.hero}>
      <div className={styles.heroGrid} aria-hidden="true" />
      <div className={styles.heroInner}>
        <div className={styles.badge}>
          <span className={styles.badgeDot} />
          flutter_modular · v7
        </div>
        <h1 className={styles.heroTitle}>
          A smart, modular
          <br />
          project structure
        </h1>
        <p className={styles.heroSubtitle}>
          Route management, dependency injection and scoped state — organized by
          feature, the Flutter way.
        </p>
        <div className={styles.heroButtons}>
          <Link
            className={clsx('button', styles.btnPrimary)}
            to="/docs/flutter_modular/start">
            Get started <span className={styles.arrow}>→</span>
          </Link>
          <Link
            className={clsx('button', styles.btnSecondary)}
            to="/docs/intro">
            Documentation
          </Link>
        </div>

        <div className={styles.terminal}>
          <div className={styles.terminalBar}>
            <span className={styles.dot} data-c="r" />
            <span className={styles.dot} data-c="y" />
            <span className={styles.dot} data-c="g" />
            <span className={styles.terminalTitle}>terminal</span>
          </div>
          <div className={styles.terminalBody}>
            <div className={styles.terminalComment}># add to your project</div>
            <div>
              <span className={styles.terminalPrompt}>$</span> flutter pub add{' '}
              <span className={styles.terminalPkg}>flutter_modular</span>
            </div>
          </div>
        </div>
      </div>
    </header>
  );
}

export default function Home() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={`${siteConfig.title} · a smart project structure`}
      description="A smart, modular project structure for Flutter — routing, dependency injection and scoped state, organized by feature.">
      <HomepageHeader />
      <main>
        <HomepageFeatures />
      </main>
    </Layout>
  );
}
