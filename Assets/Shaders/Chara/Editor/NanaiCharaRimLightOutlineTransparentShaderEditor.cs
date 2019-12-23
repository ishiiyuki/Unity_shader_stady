using UnityEngine;
using UnityEditor;
using System;

public sealed class NanaiCharaRimLightOutlineTransparentShaderEditor : ShaderGUI
{
    MaterialProperty mainTexture;
    MaterialProperty ambientColor;
    MaterialProperty diffuseRate;
    MaterialProperty rimThickness;
    MaterialProperty rimColor;

    MaterialProperty lineColor;
    MaterialProperty lineThick;

    MaterialProperty stencilMask;
    MaterialProperty stencilCompareMode;
    MaterialProperty transparent;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        mainTexture = FindProperty("_MainTex", properties);
        ambientColor = FindProperty("_AmbColor", properties);
        diffuseRate = FindProperty("_DiffuseRate", properties);
        rimThickness = FindProperty("_RimThick", properties);
        rimColor = FindProperty("_RimColor", properties);
        lineColor = FindProperty("_LineColor", properties);
        lineThick = FindProperty("_LineThick", properties);
        stencilMask = FindProperty("_Mask", properties);
        stencilCompareMode = FindProperty("_CompareMode", properties);
        transparent = FindProperty("_Transparent", properties);


        EditorGUIUtility.labelWidth = 0f;

        EditorGUI.BeginChangeCheck();
        {

        }
        EditorGUI.EndChangeCheck();


        materialEditor.TexturePropertySingleLine(new GUIContent(mainTexture.displayName, "Main Color Texture (RGB)"), mainTexture);
        materialEditor.ColorProperty(ambientColor, ambientColor.displayName);
        materialEditor.RangeProperty(diffuseRate, diffuseRate.displayName);
        materialEditor.RangeProperty(rimThickness, rimThickness.displayName);
        materialEditor.ColorProperty(rimColor, rimColor.displayName);
        materialEditor.ColorProperty(lineColor, lineColor.displayName);
        materialEditor.RangeProperty(lineThick, lineThick.displayName);

        materialEditor.FloatProperty(stencilMask, stencilMask.displayName);
        int currentCompareMode = (int)stencilCompareMode.floatValue;
        int newCompareMode = EditorGUILayout.Popup(stencilCompareMode.displayName, currentCompareMode, Enum.GetNames(typeof(UnityEngine.Rendering.CompareFunction)));
        if (currentCompareMode != newCompareMode)
        {
            stencilCompareMode.floatValue = (float)newCompareMode;
        }
        materialEditor.FloatProperty(transparent, transparent.displayName);

        materialEditor.RenderQueueField();

    }
}    