import { Fragment, h } from 'preact';

import { useState, useEffect } from 'preact/hooks';

import TabPane from 'react-bootstrap/TabPane';
import ListGroup from 'react-bootstrap/ListGroup';

import style from './style.css';

import type { FunctionalComponent } from 'preact';
import type { Container } from '~/types';

type ContainerListType =  'installed' | 'available';

interface ContainerListProps {
    type: ContainerListType;
    label: string;
}

function useContainerData(type: ContainerListType) {
    const [ data, setData ] = useState([] as Container[]);

    useEffect(
        () => {
            const ctr = window.backend.Containers;
            const method =
                type === 'installed'
                    ? ctr.ListInstalled
                    : type === 'available'
                        ? ctr.ListAvailable
                        : undefined;

            method?.().then(
                (result) => {
                    setData(result);
                }
            );
        },
        []
    );

    return data;
}

export const ContainerList: FunctionalComponent<ContainerListProps> =
    ({ type, label }) => {
        const data = useContainerData(type);

        if (data.length <= 0) return null;

        return (
            <div className={style['container-list']}>
                <h1>{label}</h1>
                <ListGroup>{
                    data.map(
                        ({ Name, Id }, idx) => (
                            <ListGroup.Item action key={Id} href={`#${Id}`}>
                                {Name}
                            </ListGroup.Item>
                        )
                    )
                }</ListGroup>
            </div>
        )
    };

interface DetailsPaneProps {
    type: ContainerListType;
}

export const DetailsPanes: FunctionalComponent<DetailsPaneProps> =
    ({ type }) => {
        const data = useContainerData(type)
        return (
            <Fragment>{
                data.map(
                    ({ Name, Id }) => (
                        <TabPane eventKey={`#${Id}`}>
                            <div>
                                Details for container "{Name}" ({Id})
                            </div>
                        </TabPane>
                    )
                )
            }</Fragment>
        )
    }

