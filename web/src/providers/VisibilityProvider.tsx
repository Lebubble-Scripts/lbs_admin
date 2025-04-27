import React, {
  Context,
  createContext,
  useContext,
  useEffect,
  useState,
} from "react";
import { useNuiEvent } from "../hooks/useNuiEvent";
import { fetchNui } from "../utils/fetchNui";
import { isEnvBrowser } from "../utils/misc";
import ReportMenu from "../components/ReportMenu";

const VisibilityCtx = createContext<VisibilityProviderValue | null>(null);

interface VisibilityProviderValue {
  setVisible: (visible: boolean) => void;
  visible: boolean;
  setReportMenuVisible: (reportMenuVisible: boolean) => void;
  reportMenuVisible: boolean;
}

// This should be mounted at the top level of your application, it is currently set to
// apply a CSS visibility value. If this is non-performant, this should be customized.
export const VisibilityProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const [visible, setVisible] = useState(false);
  const [reportMenuVisible, setReportMenuVisible] = useState(false)

  useNuiEvent<boolean>("setVisible", setVisible);
  useNuiEvent<boolean>("reportMenu", setReportMenuVisible)


  // Handle pressing escape
  useEffect(() => {
    // Only attach listener when we are visible
    if (!visible && !reportMenuVisible) return;

    const keyHandler = (e: KeyboardEvent) => {
      if (["Escape", "F3"].includes(e.code)) {
      if (!isEnvBrowser()) fetchNui("hideFrame");
      else setVisible(!visible);
      }
    };

    window.addEventListener("keydown", keyHandler);

    return () => window.removeEventListener("keydown", keyHandler);
  }, [visible, reportMenuVisible]);


  return (
    <VisibilityCtx.Provider
      value={{
        visible,
        setVisible,
        reportMenuVisible,
        setReportMenuVisible: setReportMenuVisible,
      }}
    >
    {visible && (
      <div style={{visibility: "visible", height:'100%'}}>
        {children}
      </div>
    )}
      {reportMenuVisible && (
        <div style={{ visibility: "visible", height: "100%" }}>
          {/* Render the ReportMenu component or its children */}
          <ReportMenu />
        </div>
      )}
    </VisibilityCtx.Provider>
  );
};

export const useVisibility = () =>
  useContext<VisibilityProviderValue>(
    VisibilityCtx as Context<VisibilityProviderValue>,
  );
