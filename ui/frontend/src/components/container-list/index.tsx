import { Fragment, h } from 'preact';

import { useState, useEffect } from 'preact/hooks';

import CardGroup from 'react-bootstrap/CardGroup';
import Card from 'react-bootstrap/Card';
import Box from 'react-bootstrap/Container';

import { run as runHolder } from 'holderjs';

import style from './style.module.css';

import type { FunctionalComponent } from 'preact';
import type { Container } from '~/types';

interface ListProps {
    name: string;
    contents: Container[];
}

export const ContainerList: FunctionalComponent<ListProps> =
    ({ name, contents}) => {
        useEffect(
            () => {
                runHolder(style['card-item'] as any)
            }
        );

        return (
            <Box className={style['container-list']}>
                <h1>{name}</h1>
                <div className={style['card-group']}>
                    {contents.map(
                        x => (
                            <Card key={x.Id} className={style['card-item']}>
                                <Card.Img src={`holder.js/306x160?text=${x.Name}&theme=sky`} variant="top" />
                                <Card.Body>
                                    <Card.Title>{x.Name}</Card.Title>
                                    <Card.Text>{x.Summary}</Card.Text>
                                </Card.Body>
                            </Card>
                        )
                    )}
                </div>
            </Box>
        );
    };
