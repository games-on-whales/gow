import { FunctionalComponent, h } from 'preact';

import Tab from 'react-bootstrap/Tab';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';

import { ContainerList, DetailsPanes } from '~/components/container-list';
import { Header } from '~/components/header';

import style from './app.css';
import 'bootstrap/dist/css/bootstrap.min.css';

const Content: FunctionalComponent = ({ children }) => {
    return (
        <div className={style.content}>
            {children}
        </div>
    );
};

const App: FunctionalComponent = () => {
    return (
        <div id="preact_root">
            <Header />
            <Content>
                <Tab.Container>
                    <Row>
                        <Col sm={4}>
                            <ContainerList type='installed' label='Installed' />
                            <ContainerList type='available' label='Available' />
                        </Col>
                        <Col sm={8}>
                            <Tab.Content>
                                <DetailsPanes type='installed' />
                                <DetailsPanes type='available' />
                            </Tab.Content>
                        </Col>
                    </Row>
                </Tab.Container>
            </Content>
        </div>
    );
};

export default App;
