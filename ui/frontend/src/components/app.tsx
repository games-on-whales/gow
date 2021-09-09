import { h } from 'preact';
import { useEffect, useState } from 'preact/hooks';

// not calling it "Container" to avoid conflict with the concept of docker
// containers
import Box from 'react-bootstrap/Container';
import Image from 'react-bootstrap/Image';
import Carousel from 'react-bootstrap/Carousel';
import { run as runHolder } from 'holderjs';
import Wails from '@wailsapp/runtime';

import { Header } from '~/components/header';
import { ContainerList as List } from '~/components/container-list';

import 'bootstrap/dist/css/bootstrap.min.css';
import style from './app.module.css';

import type { FunctionalComponent } from 'preact';
import type { Container, ContainerList, ContainerStore } from '~/types';

// TODO: this currently depends on the store name being the same as a Backend
// type containing a TriggerStoreUpdate method, to facilitate getting the
// subscriber called when it's initially created. This is ok for now but will
// need to be revisited later
function useStore<T>(
    storeName: keyof typeof window.backend,
    handler: (data: T) => void
): void {
    useEffect(
        () => {
            Wails.Store.New(storeName)
                .subscribe(handler)

            const backend = window.backend[storeName];
            if ('TriggerStoreUpdate' in backend) {
                backend.TriggerStoreUpdate().catch(e => console.error(e));
            }
        },
        []
    );
}

const App: FunctionalComponent = () => {
    const [ data, setData ] = useState([] as Container[]);
    const [ lists, setLists ] = useState([] as ContainerList[]);

    useStore<ContainerStore>(
        'Containers',
        (data) => {
            setData(data?.Featured ?? []);
            setLists(data?.Lists ?? []);
        }
    );

    useEffect(
        () => {
            runHolder('banner-item' as any)
        }
    );

    return (
        <div id="preact_root">
            <Header />
            <Box fluid className={style['full-width']}>
                <Carousel className={style['featured-apps']}>
                    {data.map(
                        (item, idx) => (
                            <Carousel.Item key={idx}>
                                <Image
                                    src={`holder.js/800x400?text=${item.Name}&theme=sky`}
                                    className='d-block w-100 banner-item'
                                />
                                <Carousel.Caption>
                                    <h3>{item.Name}</h3>
                                    <p>{item.Summary}</p>
                                </Carousel.Caption>
                            </Carousel.Item>
                        )
                    )}
                </Carousel>
            </Box>
            <Box>
                {/* TODO: should/could this use a Carousel for scrolling? */}
                {lists.map(
                    list => (
                        <List name={list.Name} contents={list.Contents} />
                    )
                )}
            </Box>
        </div>
    );
};

export default App;
