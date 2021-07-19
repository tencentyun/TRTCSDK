import React from 'react';
import { withRouter } from "react-router";
import { Switch, Route, Redirect } from 'react-router-dom';
import { getNavConfig } from '../api/nav';
import SideBar from '../components/SideBar';
import './home.scss'

import LogoImg from '../assets/img/logo-transparent.png'

class Home extends React.Component {
  constructor(props) {
    super(props);

    let defaultPagePath = 'basic/video-call';
    if (['#/', '#/home'].indexOf(window.location.hash) === -1) {
      defaultPagePath = window.location.hash.replace(/^#\/home\//, '')
    }
    const navInfo = getNavConfig(defaultPagePath);
    
    this.state = {
      activeId: navInfo.activeId,
      navConfig: navInfo.navConfig
    };

    this.handleRouteChange = this.handleRouteChange.bind(this);
  }

  handleRouteChange(navItem) {
    if (navItem && navItem.id) {
      this.setState({
        activeId: navItem.id
      });
      this.props.history.push(navItem.url);
    }
  }

  routeGenerate() {
    return <Switch>
      <Route exact path="/">
        <Redirect to="/home/basic/video-call" />
      </Route>
      {this.state.navConfig.map(obj => (obj.type === 'group'
        ? (obj.content || []).map(subObj =>
          <Route path={subObj.url} key={subObj.id} component={subObj.pageContent && subObj.pageContent}></Route>)
        : <Route path={obj.url} key={obj.id} component={obj.pageContent && obj.pageContent}></Route>))
      }
    </Switch>;
  };

  render() {
    return (
      <div className="home">
        <div className="left-side-bar">
          <div className="side-bar-head">
            <img src={LogoImg} alt="me" width="230" height="30"></img>
          </div>
          <SideBar data={this.state.navConfig} activeId={this.state.activeId} onItemClick={this.handleRouteChange}></SideBar>
        </div>
        <main className="main-content">
          {this.routeGenerate()}
        </main>
      </div>
    )
  }
}

export default withRouter(Home);