import { FunctionalComponent, h } from 'preact';
import { useState, useEffect } from 'preact/hooks';
import Navbar from 'react-bootstrap/Navbar';
import isDataUrl from 'valid-data-url';

import style from './style.module.css';

import logo from './gow-header.png';

// TODO: the babel plugin that does automatic clsx() or whatever.
interface ImageProps {
    source: string;
    width: number;
    height: number;
    className: string;
}

const Image: FunctionalComponent<ImageProps> =
    ({ source, ...rest }) => {
        const [ data, setData ] = useState("");
        useEffect(
            () => {
                if (isDataUrl(logo)) {
                    setData(logo);
                } else {
                    // @ts-expect-error fixing the types
                    backend.Assets.GetDataUri(logo)
                        .then(
                            (uri: any) => {
                                setData(uri);
                            }
                        );
                }
            },
            [ source ]
        );

        return data
            ? (
                <img
                    src={data}
                    alt=""
                    {...rest}
                />
            )
            : null;
    }

export const Header: FunctionalComponent = () => (
    <Navbar className={style.navbar} variant="dark">
        <Navbar.Brand href="#home">
            <Image
                source={logo}
                width={30}
                height={30}
                className="d-inline-block align-top"
            />{' '}
            Games on Whales
        </Navbar.Brand>
    </Navbar>
);
