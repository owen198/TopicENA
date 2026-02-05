import kagglehub

# https://www.kaggle.com/datasets/lburleigh/asap-2-0

# Download latest version
path = kagglehub.dataset_download("lburleigh/asap-2-0")

import os
import pandas as pd
import numpy as np


def main():

    asap_pd = pd.read_csv(path + "/ASAP2_train_sourcetexts.csv")
    
    assignment = asap_pd["assignment"].unique()[3]
    asap_assignment_pd = asap_pd[asap_pd["assignment"] == assignment]

    # asap_assignment_pd = asap_pd
    asap_assignment_pd['group'] = np.where(asap_assignment_pd['score'] <= 3, 'low', 'high')

    reflection_df = pd.DataFrame()
    reflection_df["reflection"] = asap_assignment_pd["full_text"]
    reflection_df["group"] = asap_assignment_pd["group"]
    reflection_df["id"] = asap_assignment_pd["essay_id"]

    reflection_df.to_csv("asap20.csv")


if __name__ == "__main__":
    main()