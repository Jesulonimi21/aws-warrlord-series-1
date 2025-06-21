import React from "react";


const ErrorBoundaryContext = React.createContext();

export default class ErrorBoundary extends React.Component{

    constructor(props){
        super(props);
        this.state = {hasError: false}
    }

    static getDerivedStateFromError(){
        return {hasError: true};
    }
    componentDidCatch(error, errorInfo){
        console.error({error, errorInfo});
    }

    reportError=(reportedError) => {
        this.setState({hasError:true, error: reportedError})
    }

    
    render(){
        if(this.state.hasError){
            return (<h1>An Error has happened</h1>)
        }
        return <ErrorBoundaryContext.Provider value={{reportError: this.reportError}}>
            {this.props.children}
        </ErrorBoundaryContext.Provider>
    }
}

export const useError = () => React.useContext(ErrorBoundaryContext);