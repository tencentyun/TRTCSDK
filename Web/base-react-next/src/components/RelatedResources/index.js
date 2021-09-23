import a18n from 'a18n';
import React from 'react';
import { Typography, Accordion, AccordionSummary, AccordionDetails, Link } from '@material-ui/core';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';
import styles from './list.module.scss';

function RelatedResources(props) {
  return (
    <div className={styles['related-resources-wrapper']}>
      <Accordion className={styles['accordion-container']} defaultExpanded={true}>
        <AccordionSummary
          expandIcon={<ExpandMoreIcon />}
          aria-controls="panel1a-content"
          id="panel1a-header"
          classes={{
            root: styles['accordion-summary-container'],
            content: styles['accordion-summary-content'],
          }}
        >
          <Typography>{a18n('相关资源')}</Typography>
        </AccordionSummary>
        <AccordionDetails className={styles['accordion-details-container']}>
          <ul>
          {
            props.resources.map(({ name, link }, index) => (
              <li key={index}><Link target="_blank" rel="noopener noreferrer" href={link}>{a18n(name)}</Link></li>
            ))
          }
          </ul>
        </AccordionDetails>
      </Accordion>
    </div>
  );
}


export default RelatedResources;
