import { h } from 'preact';
import { useState, useEffect } from 'preact/hooks';

import Wails from '@wailsapp/runtime';

import './style/index.css';
import App from './components/app';

import type { FunctionalComponent } from 'preact';

const Initialize: FunctionalComponent =
    () => {
        const [ isReady, setReady ] = useState(false);

        useEffect(
            () => {
                Wails.Init(() => {
                    Wails.Events.Emit('frontend-ready');
                    setReady(true);
                });
            },
            []
        );

        return isReady
            ? <App />
            : null;
    };

export default Initialize;
